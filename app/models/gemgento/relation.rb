module Gemgento
  class Relation < ActiveRecord::Base
    belongs_to :relation_type
    belongs_to :relatable, :polymorphic => true, :touch => true
    belongs_to :related_to, :polymorphic => true, :touch => true
    validates :relation_type, :relatable, :related_to, :presence => true
  end
end