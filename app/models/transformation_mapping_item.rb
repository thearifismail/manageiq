class TransformationMappingItem < ApplicationRecord
  belongs_to :transformation_mapping
  belongs_to :source,      :polymorphic => true
  belongs_to :destination, :polymorphic => true

  validates :source_id, :uniqueness => {:scope => [:transformation_mapping_id, :source_type]}

  validate :source_cluster, :if => -> { source.kind_of?(EmsCluster) }

  VALID_SOURCE_CLUSTER_PROVIDERS = %w[vmwarews].freeze

  def source_cluster
    unless VALID_SOURCE_CLUSTER_PROVIDERS.include?(source.ext_management_system.emstype)
      source_types = VALID_SOURCE_CLUSTER_PROVIDERS.join(',')
      errors.add(:sourc_type, "EMS type of source cluster must be in : #{source_types}")
    end
  end
end
