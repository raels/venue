require 'open3'
require 'tempfile'

def setup_file name, content=''
  File.open(name,'w')  {|fp| fp.write(content) } 
end 

def without_files *paths, &block
  paths = paths.map(&:to_s).select { |p| File.exist? p }
  save_files = paths.map { |p| Tempfile.new(p).tap { |fp| fp.write(File.read(p)) && fp.rewind } }
  paths.each { |p| File.unlink p }
  yield
ensure
  save_files.zip(paths) { |sf,p| setup_file(p, sf.tap(&:rewind).read) }
end

def with_files paths={}, &block 
  paths = paths.transform_keys(&:to_s)
  already_there = paths.keys.select { |p| File.exist? p }.join(', ')
  raise 'these files should not be: '+already_there unless already_there.empty?

  begin 
    paths.each { |p,v| setup_file p,v }
    yield
  ensure
    paths.keys.each { |p| File.unlink p}
    still_there = paths.keys.select { |p| File.exist? p }.join(', ')
    raise 'cannot unlink these files: '+still_there unless still_there.empty?
  end
end

def line_filter s, pattern
  s.split(/\s*\n\s*/).grep(pattern)
end 