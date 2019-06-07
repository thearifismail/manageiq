class TransformationMappingItem < ApplicationRecord
  belongs_to :transformation_mapping
  belongs_to :source,      :polymorphic => true
  belongs_to :destination, :polymorphic => true

  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type, :destination_type] }
  validates :source_type, :inclusion => { :in => %w[EmsCluster Storage Lan] }

  validate :source_cluster,      :if => -> { source.kind_of?(EmsCluster) }
  validate :destination_cluster, :if => -> { destination.kind_of?(EmsCluster) || destination.kind_of?(CloudTenant) }

  validate :source_datastore,    :if => -> { source.kind_of?(Storage) }
  validate :destination_datastore,    :if => -> { destination.kind_of?(Storage) || destination.kind_of?(CloudVolume) }



  validate :source_network,      :if => -> {source.kind_of?(Lan) }
  # validate :destination_network, :if => -> { destination.kind_of?(Lan) || destination.kind_of?(CloudNetwork) }



  VALID_SOURCE_CLUSTER_PROVIDERS = %w[vmwarews].freeze
  VALID_DESTINATION_CLUSTER_PROVIDERS = %w[rhevm openstack].freeze

  VALID_SOURCE_DATASTORE_TYPES      = %w[Storage].freeze
  VALID_DESTINATION_DATASTORE_TYPES      = %w[Storage CloudVolume].freeze



  VALID_SOURCE_NETWORK_TYPES        = %w[Lan].freeze
  VALID_DESTINATION_NETWORK_TYPES   = %w[Lan CloudNetwork].freeze



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

  # Verify that Network type is LAN and belongs the source cluster .
  #
  def source_network
    source_lan       = source
    ems_cluster_lans = source_lan.switch.host.ems_cluster.lans.flatten
    logger.info("******* source_cluster_lans: " + ems_cluster_lans.inspect)
    logger.info("******* source_cluster_lans_count: " + ems_cluster_lans.count.to_s)

    unless ems_cluster_lans.include?(source_lan)
      network_types = VALID_SOURCE_NETWORK_TYPES.join(', ')
      errors.add(:network_types, "The network type must be in: #{network_types}")
    end
  end # of source_network
# =begin
  # Verify that Network type is LAN or CloudNetwork and belongs the destination cluster.
  #
  def destination_network
    destination_lan = destination

    if destination.kind_of?(Lan) # redhat
      lans = destination_lan.switch.host.ems_cluster.lans.flatten
      logger.info("******* destination_cluster_lans: " + lans.inspect)
      logger.info("******* destination_cluster_lans_count: " + lans.count.to_s)
    elsif
      lans =  destination.cloud_tenant.cloud_networks
    else
      lan = nil
    end

    unless lans.include?(destination_lan)
      network_types = VALID_SOURCE_NETWORK_TYPES.join(', ')
      errors.add(:network_types, "The network type must be in: #{network_types}")
    end
  end # of destination_network
# =end


end
