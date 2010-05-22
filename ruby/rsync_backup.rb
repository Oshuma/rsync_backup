# Simple rsync backup.
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
    @paths.each do |path|
      # TODO: Check all paths before running.
      raise "Path not found: #{path}" unless File.exists?(path)
      puts "- #{rsync} #{path} #{@destination}"
      system "#{rsync} #{path} #{@destination}"
    end
  end

  private

  def rsync
    "#{@rsync_bin} #{@rsync_opts.join(' ')}"
  end
end
