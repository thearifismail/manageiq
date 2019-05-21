class TransformationMappingItem < ApplicationRecord

  belongs_to :transformation_mapping
  belongs_to :source,      :polymorphic => true
  belongs_to :destination, :polymorphic => true

  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type]}

  validate :source_cluster,      :if => lambda { source.kind_of?(EmsCluster) }
  # validate :destination_cluster, :if => lambda { destination.kind_of?(EmsCluster) || destination.kind_of?(CloudTennant) }

  VALID_SOURCE_CLUSTER_PROVIDERS      = %w[vmwarews].freeze
  # VALID_DESTINATION_CLUSTER_PROVIDERS = %w[rhevm openstack].freeze

  def source_cluster
    unless VALID_SOURCE_CLUSTER_PROVIDERS.include?(source.ext_management_system.emstype)
      source_types = VALID_SOURCE_CLUSTER_PROVIDERS.join(',')
      errors.add(:source, "EMS type of source cluster must be in : #{source_types}")
    end
  end
=begin
  def destination_cluster
    unless VALID_DESTINATION_CLUSTER_PROVIDERS.include?(destination.ext_management_system.emstype)
      destination_types = VALID_DESTINATION_CLUSTER_PROVIDERS.join(',')
      errors.add(:destination_type, "EMS type of target cluster must be in : #{destination_types}")
    end
  end


=begin

  belongs_to :transformation_mapping
  belongs_to :source,      :polymorphic => true
  belongs_to :destination, :polymorphic => true

  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type]}

  validate :source_cluster, :if => -> { source.kind_of?(EmsCluster) }

  VALID_SOURCE_CLUSTER_PROVIDERS = %w[vmwarews].freeze

  def source_cluster
    unless VALID_SOURCE_CLUSTER_PROVIDERS.include?(source.ext_management_system.emstype)
      source_types = VALID_SOURCE_CLUSTER_PROVIDERS.join(', ')
      errors.add(:source, "EMS type of source cluster must be in: #{source_types}")
    end
  end
=end

end
