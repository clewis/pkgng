name             'pkgng'
maintainer       'Douglas Thrift'
maintainer_email 'douglas@douglasthrift.net'
license          'Apache 2.0'
description      'Installs/Configures pkgng'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue '0.1.0'

supports 'freebsd', '>= 8.4'

depends 'line', '~> 0.5.1'
