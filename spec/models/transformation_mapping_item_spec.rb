RSpec.describe TransformationMappingItem, :v2v do
  let(:ems_vmware) { FactoryBot.create(:ems_vmware) }
  let(:vmware_cluster) { FactoryBot.create(:ems_cluster, :ext_management_system => ems_vmware) }

  let(:ems_redhat) { FactoryBot.create(:ems_redhat) }
  let(:redhat_cluster) { FactoryBot.create(:ems_cluster, :ext_management_system => ems_redhat) }

  let(:ems_openstack) { FactoryBot.create(:ems_openstack) }
  let(:openstack_cluster) { FactoryBot.create(:ems_cluster_openstack, :ext_management_system => ems_openstack) }

  context "source cluster validation" do
    let(:valid_mapping_item) do
      FactoryBot.build(:transformation_mapping_item, :source => vmware_cluster, :destination => openstack_cluster)
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
      FactoryBot.build(:transformation_mapping_item, :source => vmware_cluster, :destination => redhat_cluster)
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

  context "source datastore validation" do
    let(:src_host) { FactoryBot.create(:host_vmware, :ems_cluster => vmware_cluster) }
    let(:src)      { FactoryBot.create(:storage_vmware, :hosts => [src_host]) }

    let(:dst_host) { FactoryBot.create(:host_openstack_infra, :ems_cluster => openstack_cluster) }
    let(:dst)      { FactoryBot.create(:storage_nfs, :hosts => [dst_host]) }
    # let(:dst)      { FactoryBot.create(:cloud_volume_openstack, :hosts => [dst_host]) } # does not hosts attribute for cloud_volume_openstack, so negative is tricky. Better have a validates method to check that source and destination types are the Same.

    before do
      allow(vmware_cluster).to receive(:storages).and_return([src])
    end

    let(:valid_tmi) { FactoryBot.create(:transformation_mapping_item, :source => src, :destination => dst) }
    it "Source datasource is valid" do
      expect(valid_tmi.valid?).to be(true)
    end
  end # end of context source datastore validation
end
