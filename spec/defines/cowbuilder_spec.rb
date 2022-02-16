# frozen_string_literal: true

require 'spec_helper'

describe 'pbuilder::cowbuilder' do
  let(:title) { 'moo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pbuilder::cowbuilder::common') }

        it do
          is_expected.to contain_file('/etc/pbuilder/moo/pbuilderrc').
            with_content(%r{MIRRORSITE=""}).
            with_content(%r{DISTRIBUTION="#{facts[:os]['distro']['codename']}"}).
            with_content(%r{ARCH="#{facts[:os]['architecture']}"}).
            with_content(%r{BASEPATH="/var/cache/pbuilder/base-moo\.cow"}).
            without_content(%r{BASETGZ=})
        end
      end

      describe 'methodurl set' do
        let(:params) do
          { methodurl: 'http://ftp.debian.org/debian' }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/etc/pbuilder/moo/pbuilderrc').
            with_content(%r{MIRRORSITE="http://ftp.debian.org/debian"})
        end
      end
    end
  end
end
