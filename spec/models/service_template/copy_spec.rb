describe ServiceTemplate do
  describe "#template_copy" do
    let(:service_template_ansible_tower) { FactoryBot.create(:service_template_ansible_tower) }
    let(:service_template_orchestration) { FactoryBot.create(:service_template_orchestration) }
    let(:custom_button) { FactoryBot.create(:custom_button, :applies_to => @st1) }
    let(:custom_button_for_service) { FactoryBot.create(:custom_button, :applies_to_class => "Service") }
    let(:custom_button_set) { FactoryBot.create(:custom_button_set, :owner => @st1) }
    before do
      @st1 = FactoryBot.create(:service_template)
    end

    def copy_template(template, name = nil)
      copy = nil
      expect do
        copy = template.public_send(*[:template_copy, name].compact)
      end.to change { ServiceTemplate.count }.by(1)
      expect(copy.persisted?).to be(true)
      expect(copy.guid).not_to eq(template.guid)
      expect(copy.display).to be(false)
      copy
    end

    context "with given name" do
      it "without resource " do
        copy_template(@st1, "new_template")
      end

      it "with custom button copy only direct_custom_buttons" do
        custom_button
        custom_button_for_service
        expect(@st1.custom_buttons.count).to eq(2)
        new_service_template = copy_template(@st1, "new_template")
        expect(new_service_template.direct_custom_buttons.count).to eq(@st1.direct_custom_buttons.count)
      end

      it "with custom button it can copy a copy" do
        custom_button
        custom_button_for_service
        expect(@st1.custom_buttons.count).to eq(2)
        new_service_template = copy_template(@st1, "new_template")
        copy_of_copy = copy_template(new_service_template)
        expect(copy_of_copy.direct_custom_buttons.count).to eq(new_service_template.direct_custom_buttons.count)
      end

      it "with custom button set" do
        custom_button_set.add_member(custom_button)
        expect(@st1.custom_button_sets.count).to eq(1)
        new_service_template = copy_template(@st1, "new_template")
        expect(new_service_template.custom_button_sets.count).to eq(1)
      end

      it "with non-copyable resource (configuration script base)" do
        @st1.add_resource(FactoryBot.create(:configuration_script_base))
        new_service_template = copy_template(@st1, "new_template")
        expect(@st1.service_resources.first.resource).not_to be(nil)
        expect(new_service_template.service_resources.first.resource).to eq(@st1.service_resources.first.resource)
        expect(ConfigurationScriptBase.count).to eq(1)
      end

      it "with non-copyable resource (ext management system)" do
        @st1.add_resource(FactoryBot.create(:ext_management_system))
        new_service_template = copy_template(@st1, "new_template")
        expect(new_service_template.service_resources.first.resource_id).to eq(@st1.service_resources.first.resource_id)
        expect(ExtManagementSystem.count).to eq(1)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end

      it "with non-copyable resource (orchestration template)" do
        @st1.add_resource(FactoryBot.create(:orchestration_template))
        new_service_template = copy_template(@st1, "new_template")
        expect(new_service_template.service_resources.first.resource_id).to eq(@st1.service_resources.first.resource_id)
        expect(OrchestrationTemplate.count).to eq(1)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end

      it "with copyable resource" do
        admin = FactoryBot.create(:user_admin)
        vm_template = FactoryBot.create(:vm_openstack, :ext_management_system => FactoryBot.create(:ext_management_system))
        ptr = FactoryBot.create(:miq_provision_request_template, :requester => admin, :src_vm_id => vm_template.id)
        @st1.add_resource(ptr)
        new_service_template = copy_template(@st1, "new_template")
        expect(MiqProvisionRequestTemplate.count).to eq(2)
        expect(new_service_template.service_resources.count).not_to be(0)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end

      it "with copyable resource copies sr options" do
        admin = FactoryBot.create(:user_admin)
        vm_template = FactoryBot.create(:vm_openstack, :ext_management_system => FactoryBot.create(:ext_management_system))
        ptr = FactoryBot.create(:miq_provision_request_template, :requester => admin, :src_vm_id => vm_template.id)
        @st1.add_resource(ptr)
        @st1.service_resources.first.update_attributes(:scaling_min => 4)
        expect(@st1.service_resources.first.scaling_min).to eq(4)
        new_service_template = copy_template(@st1, "new_template")
        expect(MiqProvisionRequestTemplate.count).to eq(2)
        expect(new_service_template.service_resources.first.scaling_min).to eq(4)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end

      it "service template ansible tower with copyable resource" do
        admin = FactoryBot.create(:user_admin)
        vm_template = FactoryBot.create(:vm_openstack, :ext_management_system => FactoryBot.create(:ext_management_system))
        ptr = FactoryBot.create(:miq_provision_request_template, :requester => admin, :src_vm_id => vm_template.id)
        service_template_ansible_tower.add_resource(ptr)
        new_service_template = copy_template(service_template_ansible_tower)
        expect(MiqProvisionRequestTemplate.count).to eq(2)
        expect(new_service_template.service_resources.count).not_to be(0)
        expect(service_template_ansible_tower.service_resources.first.resource).not_to be(nil)
      end

      it "service template orchestration with copyable resource" do
        admin = FactoryBot.create(:user_admin)
        vm_template = FactoryBot.create(:vm_openstack, :ext_management_system => FactoryBot.create(:ext_management_system))
        ptr = FactoryBot.create(:miq_provision_request_template, :requester => admin, :src_vm_id => vm_template.id)
        service_template_orchestration.add_resource(ptr)
        new_service_template = copy_template(service_template_orchestration)
        expect(MiqProvisionRequestTemplate.count).to eq(2)
        expect(new_service_template.service_resources.count).not_to be(0)
        expect(service_template_orchestration.service_resources.first.resource).not_to be(nil)
      end
    end

    context "without given name" do
      it "without resource" do
        new_service_template = copy_template(@st1)
        expect(new_service_template.service_resources.count).to eq(0)
        expect(@st1.service_resources.count).to eq(0)
      end

      it "with non-copyable resource (configuration_script_base)" do
        @st1.add_resource(FactoryBot.create(:configuration_script_base))
        new_service_template = copy_template(@st1)
        expect(new_service_template.service_resources.first.resource_id).to eq(@st1.service_resources.first.resource_id)
        expect(ConfigurationScriptBase.count).to eq(1)
      end

      it "with non-copyable resource (ext management system)" do
        @st1.add_resource(FactoryBot.create(:ext_management_system))
        new_service_template = copy_template(@st1)
        expect(ServiceTemplate.where("name ILIKE ?", "Copy of service%").first.service_resources.first.resource_id).to eq(@st1.service_resources.first.resource_id)
        expect(ExtManagementSystem.count).to eq(1)
        expect(new_service_template.service_resources.count).not_to be(0)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end

      it "with non-copyable resource (orchestration template)" do
        @st1.add_resource(FactoryBot.create(:orchestration_template))
        new_service_template = copy_template(@st1)
        expect(new_service_template.service_resources.first.resource_id).to eq(@st1.service_resources.first.resource_id)
        expect(OrchestrationTemplate.count).to eq(1)
        expect(new_service_template.service_resources.count).not_to be(0)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end

      it "with copyable resource" do
        admin = FactoryBot.create(:user_admin)
        vm_template = FactoryBot.create(:vm_openstack, :ext_management_system => FactoryBot.create(:ext_management_system))
        ptr = FactoryBot.create(:miq_provision_request_template, :requester => admin, :src_vm_id => vm_template.id)
        @st1.add_resource(ptr)
        new_service_template = copy_template(@st1)
        expect(MiqProvisionRequestTemplate.count).to eq(2)
        expect(new_service_template.service_resources.count).not_to be(0)
        expect(@st1.service_resources.first.resource).not_to be(nil)
      end
    end

    context "picture" do
      it "creates a duplicate picture" do
        @st1.picture = { :content => 'foobar', :extension => 'jpg' }
        new_template = @st1.template_copy

        expect(@st1.picture.id).to_not eq(new_template.picture.id)
        expect(@st1.picture.content).to eq(new_template.picture.content)
      end

      it "leave picture nil when source template is nil" do
        new_template = @st1.template_copy

        expect(@st1.picture).to be_nil
        expect(new_template.picture).to be_nil
      end
    end

    context "resource_actions" do
      it "duplicates resource_actions" do
        @st1.resource_actions << [
          FactoryBot.create(:resource_action, :action => "Provision"),
          FactoryBot.create(:resource_action, :action => "Retire")
        ]

        new_template = @st1.template_copy
        expect(new_template.resource_actions.pluck(:action)).to match_array(%w[Provision Retire])
      end
    end

    context "additional tenants" do
      it "duplicates additional tenants" do
        @st1.additional_tenants << [
          FactoryBot.create(:tenant),
          FactoryBot.create(:tenant, :subdomain => nil)
        ]
        expect(@st1.additional_tenants.count).to eq(2)
        new_template = @st1.template_copy
        expect(new_template.additional_tenants.count).to eq(2)
      end
    end
  end
end
