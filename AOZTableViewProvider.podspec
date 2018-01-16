
Pod::Spec.new do |s|
  s.name         = "AOZTableViewProvider"
  s.version      = '0.7'
  s.summary      = "AOZTableViewProvider can generate tableView from a configuration file"
  s.description  = <<-DESC
                   AOZTableViewProvider generates UITableView from a config file, without writing any dataSource and delegate.
                   DESC
  s.requires_arc = true
  s.homepage     = "https://github.com/Aozorany/AOZTableViewProvider"
  s.license      = 'MIT'
  s.author       = "Aozorany"
  s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Aozorany/AOZTableViewProvider.git", :tag => s.version.to_s}
  s.source_files  = "AOZTableViewProvider/AOZ*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.frameworks = 'UIKit'
end
