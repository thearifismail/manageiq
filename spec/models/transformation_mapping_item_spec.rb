RSpec.describe TransformationMappingItem, :v2v do
  let(:source_ems) { FactoryBot.create(:ems_vmware) }
  let(:target_ems) { FactoryBot.create(:ems_openstack) }

  let(:source_cluster) { FactoryBot.create(:ems_cluster, :ext_management_system => source_ems) }
  let(:target_cluster) { FactoryBot.create(:ems_cluster_openstack, :ext_management_system => target_ems) }

  let(:transformation_mapping_item) {
    FactoryBot.create(:transformation_mapping_item, :source => source_cluster, :destination => target_cluster)
  }

  context "source cluster validation" do
    it "requires a valid source provider type" do
      expect(transformation_mapping_item).to be_valid
    end
  end
end
