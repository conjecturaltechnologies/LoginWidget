class Letter
  include MongoMapper::Document

  key :title,     String
  key :url,       String
  key :letter,    String
  key :voters,    Array
  key :upvotes,   Integer, :default => 0
  key :downvotes, Integer, :default => 0
  key :relevance, Integer, :default => 0

  # Cached values.
  #key :comment_count, Integer, :default => 0
  key :username,      String
  
  # Comments
  many :comments

  # Note this: ids are of class ObjectId.
  key :user_id,   ObjectId
  timestamps!
  
  # Relationships.
  belongs_to :user

  # Validations.
  validates_presence_of :title, :url, :user_id
end