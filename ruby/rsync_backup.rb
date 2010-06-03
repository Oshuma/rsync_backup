# Simple rsync backup.
# TODO: A binary with commandline options.
class RsyncBackup
  def initialize(paths, destination, options = {})
    @paths = paths.map { |p| File.expand_path(p) }
    @destination = File.expand_path(destination)

    @options = options
    @options[:mirror]  ||= false

    @rsync_bin = %x[ which rsync ].chomp
    @rsync_opts = [
      '--archive',
      '--compress',
      '--verbose',
    ]
    @rsync_opts << '--delete'  if @options[:mirror]
  end

  def run!(for_real = true)
    @rsync_opts << '--dry-run' unless for_real
    raise "Destination not found: #{@destination}" unless File.exists?(@destination)
    # Check the existence of the paths before running.
    @paths.each { |path| raise "Path not found: #{path}" unless File.exists?(path) }
    @paths.each { |path| backup(path) }
  end

  private

  def rsync
    "#{@rsync_bin} #{@rsync_opts.join(' ')}"
  end

  def backup(path)
    puts "- #{rsync} #{path} #{@destination}"
    system "#{rsync} #{path} #{@destination}"
  end
end
