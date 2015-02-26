require 'elasticsearch/model'

class Article < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
              fields: ['title', 'content']
            }
          }
        }
      )
  end

#curl -XPUT 'localhost:9200/test' -d'
#{
#  "settings" : {
#    "analysis" : {
#      "analyzer" : {
#        "my_ngram_analyzer" : {
#          "tokenizer" : "my_ngram_tokenizer"
#        }
#      },
#      "tokenizer" : {
#        "my_ngam_tokenizer" : {
#          "type" : "nGram",
#          "min_gram" : "2",
#          "max_gram" : "3",
#          "token_chars" : [ "letter", "digit"]
#        }
#      }
#    }
#  }
#}'
#
#curl 'localhost:9200/test/_analyze?pretty=1&
#analyzer=my_ngram_analyzer' -d 'FC Schalke 04'
#  #FC, Sc, Scg, ch, cha, ha, hal, al, alk, lk, lke, ke, 04




  
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'true' do
      indexes :title, analyzer: 'english'
      indexes :content, analzer: 'english'
    end
  end
end

Article.__elasticsearch__.client.indices.delete index: Article.index_name rescue nil

Article.__elasticsearch__.client.indices.create \
  index: Article.index_name,
  body: { settings: Article.settings.to_hash, mappings: Article.mappings.to_hash }

Article.import
