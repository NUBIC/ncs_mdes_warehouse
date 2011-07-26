require 'rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ncs_navigator/warehouse'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.after do
    FileUtils.rm_rf @tmpdir if @tmpdir && !ENV['KEEP_TMP']
  end

  def tmpdir(*path)
    @tmpdir ||= File.expand_path('../../tmp', __FILE__).
      tap { |p| FileUtils.mkdir_p p }
    if path.empty?
      @tmpdir
    else
      File.join(@tmpdir, *path).tap { |p| FileUtils.mkdir_p p }
    end
  end
end
