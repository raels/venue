# frozen_string_literal: true

require 'open3'
require 'tempfile'

def setup_file(name, content = ' ')
  File.open(name, 'w') { |fp| fp.write(content) }
end

def without_files(*paths)
  paths = paths.map(&:to_s).select { |p| File.exist? p }
  save_files = save_as_temp_files paths
  paths.each { |p| File.unlink p }
  yield
ensure
  save_files.zip(paths) { |sf, p| setup_file(p, sf.tap(&:rewind).read) }
end

def save_as_temp_files(paths)
  paths.map do |p|
    fp = Tempfile.new(p)
    fp.write(File.read(p))
    fp.rewind
  end
end

def with_files(paths = {})
  paths = transform_and_verify_not_clobbering paths
  begin
    paths.each { |p, v| setup_file p, v }
    yield
  ensure
    teardown_paths paths
  end
end

def transform_and_verify_not_clobbering(paths)
  paths = paths.transform_keys(&:to_s)
  already_there = paths.keys.select { |p| File.exist? p }.join(', ')
  raise "these files should not be: #{already_there}" unless already_there.empty?
end

def teardown_paths(paths)
  paths.each_key { |p| File.unlink p }
  still_there = paths.keys.select { |p| File.exist? p }.join(', ')
  raise "cannot unlink these files: #{still_there}" unless still_there.empty?
end

def line_filter(str, pattern)
  str.split(/\s*\n\s*/).grep(pattern)
end
