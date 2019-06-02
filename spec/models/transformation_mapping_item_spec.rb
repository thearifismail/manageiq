RSpec.describe TransformationMappingItem, :v2v do
  let(:ems_vmware) { FactoryBot.create(:ems_vmware) }
  let(:vmware_cluster) { FactoryBot.create(:ems_cluster, :ext_management_system => ems_vmware) }

  let(:ems_redhat) { FactoryBot.create(:ems_redhat) }
  let(:redhat_cluster) { FactoryBot.create(:ems_cluster, :ext_management_system => ems_redhat) }

  let(:ems_openstack) { FactoryBot.create(:ems_openstack) }
  let(:openstack_cluster) { FactoryBot.create(:ems_cluster_openstack, :ext_management_system => ems_openstack) }

  context "source cluster validation" do
    let(:valid_mapping_item) do
      FactoryBot.create(:transformation_mapping_item, :source => vmware_cluster, :destination => openstack_cluster)
    end

    let(:invalid_mapping_item) do
      FactoryBot.build(:transformation_mapping_item, :source => openstack_cluster, :destination => openstack_cluster)
    end

    it "passes validation if the source cluster is not a supported type" do
      expect(valid_mapping_item.valid?).to be true
    end

    it "fails validation if the source cluster is not a supported type" do
      expect(invalid_mapping_item.valid?).to be false
      expect(invalid_mapping_item.errors[:source].first).to match("EMS type of source cluster must be in")
    end
  end # of source cluster validation

  context "destination cluster validation" do
    let(:valid_mapping_item) do
      FactoryBot.create(:transformation_mapping_item, :source => vmware_cluster, :destination => redhat_cluster)
    end

    let(:invalid_mapping_item) do
      FactoryBot.build(:transformation_mapping_item, :source => vmware_cluster, :destination => vmware_cluster)
    end

    it "passes validation if the source cluster is not a supported type" do
      expect(valid_mapping_item.valid?).to be true
    end

    it "fails validation if the source cluster is not a supported type" do
      expect(invalid_mapping_item.valid?).to be false
      expect(invalid_mapping_item.errors[:destination].first).to match("EMS type of destination cluster or cloud tenant must be in")
    end
  end # of destination cluster validation

  context "datastore validation" do
    let(:src_host) { FactoryBot.create(:host_vmware, :ems_cluster => vmware_cluster) }
    let(:src)      { FactoryBot.create(:storage_vmware, :hosts => [src_host]) }

    let(:ems) { FactoryBot.create(:ems_openstack) }
    let(:disk) { FactoryBot.create(:disk) }
    let(:cloud_tenant) { FactoryBot.create(:cloud_tenant_openstack, :ext_management_system => ems) }
    let(:cloud_volume_openstack) {FactoryBot.create(:cloud_volume_openstack, :attachments => [disk], :cloud_tenant => cloud_tenant) }

    before do
      allow(vmware_cluster).to receive(:storages).and_return([src])
    end

    context "source validation" do
      let(:valid_tmi_vmw) { FactoryBot.create(:transformation_mapping_item, :source => src, :destination => cloud_volume_openstack) }
      let(:invalid_tmi_vmw) { FactoryBot.build(:transformation_mapping_item, :source => cloud_volume_openstack, :destination => cloud_volume_openstack) }

      # Arif delete me
      require 'PP'

      it "Source datasource is valid" do
        expect(valid_tmi_vmw.valid?).to be(true)
      end

      it "Source datasource is invalid" do
        expect(invalid_tmi_vmw.valid?).to be(false)
      end
    end # of vmware source

    context "destination validation" do
      context "valid destination" do
        let(:valid_tmi_ops) { FactoryBot.create(:transformation_mapping_item, :source => src, :destination => cloud_volume_openstack) }

        it "openstack is valid" do
          expect(valid_tmi_ops.valid?).to be(true)
        end
      end # of openstack destination

      context "redhat" do
        let(:dst_host_rh) { FactoryBot.create(:host_redhat, :ems_cluster => redhat_cluster) }
        let(:dst_rh)      { FactoryBot.create(:storage_nfs, :hosts => [dst_host_rh]) }
        before do
          allow(redhat_cluster).to receive(:storages).and_return([dst_rh])
        end

        let(:valid_tmi_rh) { FactoryBot.create(:transformation_mapping_item, :source => src, :destination => dst_rh) }
        it "redhat destination datasource is valid" do
          expect(valid_tmi_rh.valid?).to be(true)
        end
      end # redhat destination
    end # destination datatore validation
  end # of datastore context
end
