require 'spec_helper'
describe 'puppetserver::config' do

  let(:facts) { { :puppetversion => '4.5.0' } }

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('puppetserver::config') }
    it {
      should contain_file_line('ca.certificate-authority-service').with({
        'line' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'path' => '/etc/puppetlabs/puppetserver/bootstrap.cfg',
      })
    }
    it {
      should contain_file_line('ca.certificate-authority-disabled-service').with({
        'line' => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'path' => '/etc/puppetlabs/puppetserver/bootstrap.cfg',
      })
    }
  end

  describe 'enable_ca' do
    ['true',true].each do |value|
      context "as #{value}" do
        let(:params) { { :enable_ca => value } }
        it { should compile.with_all_deps }
        it {
          should contain_file_line('ca.certificate-authority-service').with({
            'line' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
          })
        }
        it {
          should contain_file_line('ca.certificate-authority-disabled-service').with({
            'line' => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
          })
        }
      end
    end

    ['false',false].each do |value|
      context "as #{value}" do
        let(:params) { { :enable_ca => value } }
        it { should compile.with_all_deps }
        it {
          should contain_file_line('ca.certificate-authority-service').with({
            'line' => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
          })
        }
        it {
          should contain_file_line('ca.certificate-authority-disabled-service').with({
            'line' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
          })
        }
      end
    end

    context 'with invalid value' do
      let(:params) { { :enable_ca => 'not-a-boolean' } }

      it 'should fail' do
        expect {
          should contain_class('puppetserver::config')
        }.to raise_error(Puppet::Error, /Unknown type of boolean given/)
      end
    end

    describe 'with config file containing enabled ca' do
      let(:params) { { :enable_ca => true } }

      context 'with puppetserver version < 4.0.0' do
        let(:facts) { { :puppetversion => '3.8.0' } }

        it {
          should contain_file_line('ca.certificate-authority-service').with_path('/etc/puppetserver/bootstrap.cfg')
        }
      end

      context 'with puppetserver version >= 4.0.0 and <= 4.5.0' do
        let(:facts) { { :puppetversion => '4.5.0' } }

        it {
          should contain_file_line('ca.certificate-authority-service').with_path('/etc/puppetlabs/puppetserver/bootstrap.cfg')
        }
      end

      context 'with puppetserver version >= 4.6.0' do
        let(:facts) { { :puppetversion => '4.6.0' } }

        it {
          should contain_file_line('ca.certificate-authority-service').with_path('/etc/puppetlabs/puppetserver/services.d/ca.cfg')
        }
      end
    end

  end
end
