RSpec.describe TransformationMappingItem, :v2v do
  let(:ems_vmware)     { FactoryBot.create(:ems_vmware) }
  let(:ems_openstack)  { FactoryBot.create(:ems_openstack) }

  let(:vmware_cluster)    { FactoryBot.create(:ems_cluster, :ext_management_system => ems_vmware) }
  let(:openstack_cluster) { FactoryBot.create(:ems_cluster_openstack, :ext_management_system => ems_openstack) }

  context "source cluster validation" do
    let(:valid_mapping_item) {
      FactoryBot.build(:transformation_mapping_item, :source => vmware_cluster, :destination => openstack_cluster)
    }

    let(:invalid_mapping_item) {
      FactoryBot.build(:transformation_mapping_item, :source => openstack_cluster, :destination => openstack_cluster)
    }

    it "passes validation if the source cluster is not a supported type" do
      expect(valid_mapping_item.valid?).to be true
    end

    it "fails validation if the source cluster is not a supported type" do
      expect(invalid_mapping_item.valid?).to be false
      expect(invalid_mapping_item.errors[:source].first).to match("EMS type of source cluster must be in")
    end
  end
end
