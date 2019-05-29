class TransformationMappingItem < ApplicationRecord
  belongs_to :transformation_mapping
  belongs_to :source,      :polymorphic => true
  belongs_to :destination, :polymorphic => true

  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type]}

  validate :source_cluster,      :if => -> { source.kind_of?(EmsCluster) }
  validate :destination_cluster, :if => -> { destination.kind_of?(EmsCluster) || destination.kind_of?(CloudTenant) }

  validate :source_datastore,    :if => -> { source.kind_of?(Storage) }

  VALID_SOURCE_CLUSTER_PROVIDERS = %w[vmwarews].freeze
  VALID_DESTINATION_CLUSTER_PROVIDERS = %w[rhevm openstack].freeze

  VALID_SOURCE_DATASTORE_TYPES      = %w[Storage].freeze

  def source_cluster
    unless VALID_SOURCE_CLUSTER_PROVIDERS.include?(source.ext_management_system.emstype)
      source_types = VALID_SOURCE_CLUSTER_PROVIDERS.join(', ')
      errors.add(:source, "EMS type of source cluster must be in: #{source_types}")
    end
  end

  def destination_cluster
    unless VALID_DESTINATION_CLUSTER_PROVIDERS.include?(destination.ext_management_system.emstype)
      destination_types = VALID_DESTINATION_CLUSTER_PROVIDERS.join(', ')
      errors.add(:destination, "EMS type of destination cluster or cloud tenant must be in: #{destination_types}")
    end
  end

  def source_datastore
    source_storage = source

    cluster_storages = source.hosts # Get hosts using this source storage
                             .collect(&:ems_cluster) # How many clusters does each host has
                             .collect(&:storages).flatten # How many storages each host is mapped to that belong to the cluster

    unless cluster_storages.include?(source_storage)
      storage_types = VALID_SOURCE_DATASTORE_TYPES.join(', ')
      errors.add(:source, "The type of source type must be in: #{storage_types}")
    end
  end
end
