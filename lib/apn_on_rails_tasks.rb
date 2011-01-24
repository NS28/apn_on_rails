Dir.glob(File.join(File.dirname(__FILE__), 'apn', 'tasks', '**/*.rake')).each do |f|
  load File.expand_path(f)
end
