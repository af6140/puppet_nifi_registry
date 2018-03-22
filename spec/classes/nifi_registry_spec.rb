require 'spec_helper'

describe 'nifi_registry' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')
  id_mappings = hiera.lookup('nifi_registry_profiles::id_mapping', nil, 'common')
  #ENV["FUTURE_PASER"]= "yes"
  puts id_mappings
  context 'supported operating systems with no ldap and manage_repo is true' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts[:concat_basedir] = '/tmp'
          facts
        end

        let(:params) {
          {
            :initial_admin_identity => 'nifi-registry-admin',
            :admin_cert_path => '/tmp/admin.crt',
            :admin_key_path => '/tmp/admin.key',
            :manage_repo => true,
            :nifi_access_nodes => ['nifi-as01a', 'nifi-as02a', 'nifi-as03a'],
            :id_mappings => [],
          }
        }

        context "nifi_registry class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('nifi_registry::params') }
          it { is_expected.to contain_class('nifi_registry::install').that_comes_before('nifi_registry::config') }
          it { is_expected.to contain_class('nifi_registry::config') }
          it { is_expected.to contain_class('nifi_registry::service').that_subscribes_to('nifi_registry::config') }

          it { is_expected.to contain_service('nifi-registry') }
          it { is_expected.to contain_package('nifi-registry').with_ensure('present') }

          it { is_expected.to contain_nifi_registry__user_group__file_provider('file_user_group_provider')  }
          it { is_expected.to contain_concat__fragment('user_group_frag_file-user-group-provider')
            .with_content(/<property name="Initial User Identity 1">nifi-registry-admin<\/property>/)
          }
          it { is_expected.not_to contain_nifi_registry__ldap_provider('ldap_provider')  }
          it { is_expected.not_to contain_nifi_registry__user_group__ldap_provider('ldap_user_group_provider')  }

        end
      end
    end
  end

  context 'supported operating systems with ldap and manage_repo is false' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts[:concat_basedir] = '/tmp'
          facts
        end

        let(:params) {
          {
            :initial_admin_identity => 'nifi-registry-admin',
            :admin_cert_path => '/tmp/admin.crt',
            :admin_key_path => '/tmp/admin.key',
            :manage_repo => false,
            :ldap_identity_provider_properties => {
              :authentication_strategy => 'SIMPLE',
            },
            :ldap_user_group_properties => {
              :user_group_name_attribute => 'member',
            },
            :id_mappings => id_mappings,
          }
        }

        context "nifi_registry class without any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_service('nifi-registry') }
          it { is_expected.to contain_package('nifi-registry').with_ensure('present') }

          it { is_expected.to contain_nifi_registry__ldap_provider('ldap_provider')  }
          it { is_expected.to contain_nifi_registry__user_group__ldap_provider('ldap_user_group_provider')  }

          it { is_expected.to contain_concat__fragment('user_group_frag_ldap-user-group-provider')
            .with_content(/<property name="Authentication Strategy">SIMPLE<\/property>/)
          }
          it { is_expected.to contain_concat__fragment('user_group_frag_composite-user-group-provider')
            .with_content(/<property name="User Group Provider 1">file-user-group-provider<\/property>/)
            .with_content(/<property name="User Group Provider 2">ldap-user-group-provider<\/property>/)
          }
          it { is_expected.to contain_nifi_registry__idmapping_dn('ldap_id_mapping_0') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'nifi_registry class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('nifi_registry') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
