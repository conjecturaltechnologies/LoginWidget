class Letter
  include MongoMapper::Document

  key :title,     String
  key :url,       String
  key :letter,    String
  key :upvotes,   Array
  key :downvotes, Array
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
  #validates_presence_of :title
end