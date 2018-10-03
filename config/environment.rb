require 'bundler'
require 'ruby_linear_regression'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = nil
require_all 'lib'
require_all 'app/models'
