require 'digest/sha1'
require 'fileutils'
require 'pathname'

set :application, 'mastodon'

set :exclude_from_package, ['tmp', 'log', 'spec', '.sass-cache', 'build', 'public/system', 'public/pack-test', '.env', '.env.production', 'db/*.sqlite3', 'db/*.sqlite3-journal', 'coverage']
set :dereference_symlinks, true

set :build_from, '.'
set :build_to, './build'

Dir.mkdir build_to unless File.exist?(build_to)

fake_env = {
  'RAILS_ENV' => 'production',
  'SECRET_KEY_BASE' => SecureRandom.hex,
}

set :bundle_without, [:development, :test]
set :bundle_dir, "#{deploy_to}/shared/bundle"

build 'assets_compile' do
  run 'bundle', 'exec', 'rake', 'assets:clobber', 'assets:precompile', fake_env
end
