require 'spec_helper'

describe 'pbuilder' do
  let (:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should compile.with_all_deps }
    end
  end
end
