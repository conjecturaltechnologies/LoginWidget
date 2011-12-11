class Comment
  include MongoMapper::Document
  
  key :Body,  String
  belongs_to :letter
end