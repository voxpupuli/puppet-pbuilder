require 'spec_helper'

describe 'pbuilder::cowbuilder' do
  let (:title) { 'foo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { should compile.with_all_deps }
    end
  end
end
