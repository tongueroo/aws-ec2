require "cfn_status"

class Forger::S3
  class Bucket
    STACK_NAME = ENV['FORGER_STACK_NAME'] || "forger"
    include Forger::AwsServices
    extend Forger::AwsServices

    class << self
      @@name = nil
      def name
        return @@name if @@name # only memoize once bucket has been created

        stack = new.find_stack
        return unless stack

        resp = cfn.describe_stack_resources(stack_name: STACK_NAME)
        bucket = resp.stack_resources.find { |r| r.logical_resource_id == "Bucket" }
        @@name = bucket.physical_resource_id # actual bucket name
      end

      def ensure_exists!
        bucket = new
        return if bucket.exist?
        bucket.create
      end
    end

    def initialize(options={})
      @options = options
    end

    def deploy
      stack = find_stack
      if stack
        update
      else
        create
      end
    end

    def exist?
      !!bucket_name
    end

    def bucket_name
      self.class.name
    end

    def show
      if bucket_name
        puts "Forger bucket name: #{bucket_name}"
      else
        puts "Forger bucket does not exist yet."
      end
    end

    # Launches a cloudformation to create an s3 bucket
    def create
      puts "Creating #{STACK_NAME} stack with the s3 bucket"
      cfn.create_stack(stack_name: STACK_NAME, template_body: template_body)
      status = CfnStatus.new(STACK_NAME)
      status.wait
    end

    def update
      puts "Updating #{STACK_NAME} stack with the s3 bucket"
      cfn.update_stack(stack_name: STACK_NAME, template_body: template_body)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      raise unless e.message.include?("No updates are to be performed")
    end

    def delete
      are_you_sure?

      puts "Deleting #{STACK_NAME} stack with the s3 bucket"
      empty_bucket!
      cfn.delete_stack(stack_name: STACK_NAME)
    end

    def find_stack
      resp = cfn.describe_stacks(stack_name: STACK_NAME)
      resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError
      nil
    end

  private

    def empty_bucket!
      resp = s3.list_objects(bucket: bucket_name)
      if resp.contents.size > 0
        # IE: objects = [{key: "objectkey1"}, {key: "objectkey2"}]
        objects = resp.contents.map { |item| {key: item.key} }
        s3.delete_objects(
          bucket: bucket_name,
          delete: {
            objects: objects,
            quiet: false,
          }
        )
        empty_bucket! # keep deleting objects until bucket is empty
      end
    end


    def are_you_sure?
      return true if @options[:sure]

      puts "Are you sure you want the forger bucket #{bucket_name.color(:green)} to be emptied and deleted? (y/N)"
      sure = $stdin.gets.strip
      yes = sure =~ /^Y/i
      unless yes
        puts "Phew that was close."
        exit
      end
    end

    def template_body
      <<~YAML
        Resources:
          Bucket:
            Type: AWS::S3::Bucket
            Properties:
              Tags:
                - Key: Name
                  Value: forger
      YAML
    end
  end
end
