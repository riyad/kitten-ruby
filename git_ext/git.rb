
module Git
  def self.repository?(path)
    File.directory? File.join(path, '.git')
  end
end
