# require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
# require 'rake/contrib/rubyforgepublisher'
require 'lib/im_contacts'

PKG_VERSION = Contacts::VERSION

PKG_FILES = FileList[
    "lib/**/*", "bin/*", "test/**/*", "[A-Z]*", "Rakefile", "doc/**/*", "examples/**/*"
] - ["test/accounts.yml"]

desc "Default Task"
task :default => [ :test ]

# Run the unit tests
desc "Run all unit tests"
Rake::TestTask.new("test") { |t|
  t.libs << "lib"
  t.pattern = 'test/*/*_test.rb'
  t.verbose = true
}

# Make a console, useful when working on tests
desc "Generate a test console"
task :console do
   verbose( false ) { sh "irb -I lib/ -r 'contacts'" }
end

# Genereate the RDoc documentation
desc "Create documentation"
Rake::RDocTask.new("doc") { |rdoc|
  rdoc.title = "Contact List - ridiculously easy contact list information from various providers including Yahoo, Gmail, and Hotmail"
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

# Genereate the package
spec = Gem::Specification.new do |s|

  #### Basic information.

  s.name = 'im_contacts'
  s.version = PKG_VERSION
  s.summary = <<-EOF
   A universal interface to grab contact list information from various providers including Yahoo, AOL, Gmail, Hotmail, 126, 163, Yeah, Sohu, Sina and Plaxo.It is extended from contacts gem.
  EOF
  s.description = <<-EOF
   A universal interface to grab contact list information from various providers including Yahoo, AOL, Gmail, Hotmail, 126, 163, Yeah, Sohu, Sina and Plaxo.It is extended from contacts gem.
  EOF

  #### Which files are to be included in this gem?  Everything!  (Except CVS directories.)

  s.files = PKG_FILES

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'
  s.autorequire = 'contacts'

  s.add_dependency('json', '>= 0.4.1')
  s.add_dependency("gdata19", "~> 0.1.9.2")
  s.requirements << "A json parser, the gdata ruby gem"

  #### Documentation and testing.

  s.has_rdoc = true

  #### Author and project details.

  s.authors = ["Mike Liang"]
  s.email = ["liangwenke.com@gmail.com"]
  s.homepage = "http://github.com/liangwenke/im_contacts"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(
    ["Library", "lib"],
    ["Units", "test"]
  ).to_s
end
