require 'spec_helper'
describe 'pbuilder' do
  let (:title) { 'foo' }

  it { should compile.with_all_deps }
end
