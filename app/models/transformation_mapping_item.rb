class TransformationMappingItem < ApplicationRecord
  belongs_to :transformation_mapping
  belongs_to :source,      :polymorphic => true
  belongs_to :destination, :polymorphic => true

<<<<<<< HEAD
  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type, :destination_type]}

  # todo provide a validate method to verify that source and destion are of the same type but different IDs

  validate :source_cluster,      :if => -> { source.kind_of?(EmsCluster) }
  validate :destination_cluster, :if => -> { destination.kind_of?(EmsCluster) || destination.kind_of?(CloudTenant) }

  validate :source_datastore,    :if => -> { source.kind_of?(Storage) }
  validate :destination_datastore,    :if => -> { destination.kind_of?(Storage) || destination.kind_of?(CloudVolume) }
=======
  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type]}

  validate :source_cluster,      :if => -> { source.kind_of?(EmsCluster) }
  validate :destination_cluster, :if => -> { source.kind_of?(EmsCluster) || source.kind_of?(CloudTenant) }
>>>>>>> master

  VALID_SOURCE_CLUSTER_PROVIDERS = %w[vmwarews].freeze
  VALID_DESTINATION_CLUSTER_PROVIDERS = %w[rhevm openstack].freeze

<<<<<<< HEAD
  VALID_SOURCE_DATASTORE_TYPES      = %w[Storage].freeze
  VALID_DESTINATION_DATASTORE_TYPES      = %w[Storage CloudVolume].freeze

=======
>>>>>>> master
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
<<<<<<< HEAD

  def source_datastore
    source_storage = source

    cluster_storages = source.hosts # Get hosts using this source storage
                             .collect(&:ems_cluster) # How many clusters does each host has
                             .collect(&:storages).flatten # How many storages each host is mapped to that belong to the cluster

    unless cluster_storages.include?(source_storage)
      storage_types = VALID_SOURCE_DATASTORE_TYPES.join(', ')
      errors.add(:source, "Source type must be in: #{storage_types}")
    end
  end

  def destination_datastore
    destionation_storage = destination

    if destination.kind_of?(Storage) # red hat
      dst_storages = destination.hosts
                                .collect(&:ems_cluster)
                                .collect(&:storages).flatten

    elsif destination.kind_of?(CloudVolume) # Openstack
      dst_storages = destination.cloud_tenant.cloud_volumes

    else
      dst_storages = nil # no storages found

    end

    unless dst_storages.include?(destionation_storage)
      storage_types = VALID_DESTINATION_DATASTORE_TYPES.join(', ')
      errors.add(:destination, "Destination type must be in: #{storage_types}")
    end
  end
=======
>>>>>>> master
end
