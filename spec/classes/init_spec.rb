require 'spec_helper'
describe 'puppetserver' do

  let(:facts) { { :puppetversion => '4.5.0' } }

  context 'with defaults for all parameters' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('puppetserver') }
    it { is_expected.to contain_class('puppetserver::config') }
    it { is_expected.to contain_package('puppetserver').with_ensure('installed') }

    it {
      is_expected.to contain_service('puppetserver').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }
  end

  describe 'package_name' do
    context "specified as string" do
      let(:params) { { :package_name => 'puppetserver_new' } }
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('puppetserver_new') }
    end

    context "specified as array" do
      let(:params) { { :package_name => ['pkg1','pkg2'] } }
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('pkg1') }
      it { is_expected.to contain_package('pkg2') }
    end
  end

  context "service_name specified" do
    let(:params) { { :service_name => 'puppetserver_alt' } }
    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_service('puppetserver_alt').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }
  end

  describe 'service_enable' do
    ['true',true].each do |value|
      context "as #{value}" do
        let(:params) { { :service_enable => value } }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('puppetserver').with_enable(true) }
      end
    end

    ['false',false].each do |value|
      context "as #{value}" do
        let(:params) { { :service_enable => value } }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('puppetserver').with_enable(false) }
      end
    end

    context 'with invalid value' do
      let (:params) { { :service_enable => 'not-a-boolean' } }

      it 'should fail' do
        expect {
          is_expected.to contain_class('puppetserver')
        }.to raise_error(Puppet::Error, /Unknown type of boolean given/)
      end
    end
  end

  describe 'validate bootstrap_settings' do
    context 'when puppetserver version > 4.5.0' do
      let(:facts) { { :puppetversion => '4.6.0' } }
      let(:params) { { :bootstrap_settings => 'settings' } }

      it 'should fail' do
        expect {
          is_expected.to contain_class('puppetserver')
        }.to raise_error(Puppet::Error, /bootstrap_settings is only valid for puppet version 4.5.0 or older/)
      end
    end

    context 'when puppetserver == 4.5' do
      $settings = { 'dummy' => { 'line' => 'yadiyadiyada' } }
      let(:facts) { { :puppetversion => '4.5.0' } }
      let(:params) { { :bootstrap_settings => $settings } }

      it { is_expected.to compile.with_all_deps }
    end
  end

end
