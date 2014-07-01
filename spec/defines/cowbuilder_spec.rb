require 'spec_helper'
describe 'pbuilder::cowbuilder' do
  let (:title) { 'foo' }
  let (:facts) { {
    :osfamily        => 'Debian',
    :lsbdistcodename => 'wheezy',
    :architecture    => 'amd64',
    :id              => 'root',
    :path            => '/foo',
  } }

  it { should compile.with_all_deps }
end
