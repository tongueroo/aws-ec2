$:.unshift(File.expand_path("../", __FILE__))
require "aws_ec2/version"
require "colorize"

module AwsEc2
  autoload :Help, "aws_ec2/help"
  autoload :Command, "aws_ec2/command"
  autoload :CLI, "aws_ec2/cli"
  autoload :AwsServices, "aws_ec2/aws_services"
  autoload :Profile, "aws_ec2/profile"
  autoload :Base, "aws_ec2/base"
  autoload :Create, "aws_ec2/create"
  autoload :Ami, "aws_ec2/ami"
  autoload :TemplateHelper, "aws_ec2/template_helper"
  autoload :Script, "aws_ec2/script"
  autoload :Config, "aws_ec2/config"
  autoload :Core, "aws_ec2/core"
  autoload :Dotenv, "aws_ec2/dotenv"
  autoload :Hook, "aws_ec2/hook"
  autoload :Compile, "aws_ec2/compile"
  autoload :S3, "aws_ec2/s3"

  extend Core
end

AwsEc2::Dotenv.load!
