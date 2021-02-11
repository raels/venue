# frozen_string_literal: true
require 'open3'

def run_cmd *args, &block
  block ||=  lambda { |*args| args }
  output, errors, status = Open3.capture3(*args)
  block.call output.strip, errors, status
end
