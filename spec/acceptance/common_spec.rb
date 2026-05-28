# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'pbuilder::common' do
  describe 'with defaults' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include pbuilder::common
        PUPPET
      end
    end

    describe package('pbuilder') do
      it { is_expected.to be_installed }
    end
  end
end
