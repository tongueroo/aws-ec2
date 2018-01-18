$:.unshift(File.expand_path("../", __FILE__))
require "aws_ec2/version"

module AwsEc2
  autoload :Help, "aws_ec2/help"
  autoload :Command, "aws_ec2/command"
  autoload :CLI, "aws_ec2/cli"
end
