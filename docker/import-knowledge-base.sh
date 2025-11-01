#!/bin/bash

# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch to be ready..."
until curl -s http://elasticsearch:9200/_cluster/health | grep -q '"status":"green\|yellow"'; do
    sleep 2
done

echo "Elasticsearch is ready!"

# Import knowledge base data
for json_file in /usr/share/elasticsearch/knowledge-base-data/*.json; do
    filename=$(basename "$json_file" .json)
    index_name="${filename//-/_}"
    
    echo "Creating index: $index_name"
    
    # Create index with tibetan analyzer
    curl -X PUT "http://elasticsearch:9200/$index_name" -H 'Content-Type: application/json' -d '{
      "settings": {
        "analysis": {
          "analyzer": {
            "tibetan": {
              "type": "tibetan_analyzer"
            }
          }
        }
      },
      "mappings": {
        "properties": {
          "question": {
            "type": "text",
            "analyzer": "tibetan"
          },
          "answer": {
            "type": "text",
            "analyzer": "tibetan"
          }
        }
      }
    }'
    
    echo ""
    echo "Importing data from $filename to index $index_name..."
    
    # Read JSON array and index documents
    cat "$json_file" | jq -c '.[]' | while read -r doc; do
        curl -X POST "http://elasticsearch:9200/$index_name/_doc" \
            -H 'Content-Type: application/json' \
            -d "$doc" > /dev/null 2>&1
    done
    
    # Get document count
    count=$(curl -s "http://elasticsearch:9200/$index_name/_count" | jq -r '.count')
    echo "✓ Imported $count documents to $index_name"
    echo ""
done

echo "All knowledge base data imported successfully!"

