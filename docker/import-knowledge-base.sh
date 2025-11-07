#!/bin/bash
set -e

ES_URL="http://elasticsearch:9200"

echo "========================================="
echo "Knowledge Base Data Import Script"
echo "========================================="

# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch to be ready..."
until curl -s "$ES_URL/_cluster/health" > /dev/null; do
    echo "Elasticsearch not ready yet, waiting..."
    sleep 2
done

echo "Elasticsearch is ready!"
echo ""

# Import knowledge base data
for json_file in /usr/share/elasticsearch/knowledge-base-data/*.json; do
    filename=$(basename "$json_file" .json)
    index_name="${filename//-/_}"
    
    echo "========================================="
    echo "Processing index: $index_name"
    echo "========================================="
    
    # Check if index already exists
    if curl -s -f "$ES_URL/$index_name" > /dev/null 2>&1; then
        echo "Index '$index_name' already exists. Deleting..."
        curl -X DELETE "$ES_URL/$index_name"
        echo ""
    fi
    
    # Create index with tibetan analyzer and proper settings
    echo "Creating index '$index_name' with Tibetan analyzer mappings..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$ES_URL/$index_name" -H 'Content-Type: application/json' -d '{
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "analysis": {
          "analyzer": {
            "my_tibetan": {
              "type": "tibetan_analyzer"
            }
          }
        }
      },
      "mappings": {
        "properties": {
          "question": {
            "type": "text",
            "analyzer": "my_tibetan",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "answer": {
            "type": "text",
            "analyzer": "my_tibetan"
          },
          "category": {
            "type": "keyword"
          },
          "source": {
            "type": "keyword"
          }
        }
      }
    }')
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "Index created successfully!"
    else
        echo "Failed to create index (HTTP $HTTP_CODE)"
        echo "$BODY"
        continue
    fi
    
    echo ""
    echo "Importing data from $filename..."
    
    # Read JSON array and index documents
    IMPORT_COUNT=0
    cat "$json_file" | jq -c '.[]' | while read -r doc; do
        RESULT=$(curl -s -w "\n%{http_code}" -X POST "$ES_URL/$index_name/_doc" \
            -H 'Content-Type: application/json' \
            -d "$doc")
        
        DOC_HTTP_CODE=$(echo "$RESULT" | tail -n1)
        if [ "$DOC_HTTP_CODE" = "201" ]; then
            IMPORT_COUNT=$((IMPORT_COUNT + 1))
        fi
    done
    
    # Refresh index
    echo "Refreshing index..."
    curl -s -X POST "$ES_URL/$index_name/_refresh" > /dev/null
    
    # Get document count
    COUNT_RESPONSE=$(curl -s "$ES_URL/$index_name/_count")
    FINAL_COUNT=$(echo "$COUNT_RESPONSE" | jq -r '.count // 0')
    
    echo "✓ Imported $FINAL_COUNT documents to $index_name"
    echo ""
done

echo "========================================="
echo "All Knowledge Base Data Imported!"
echo "========================================="
echo ""
echo "Created indices:"
echo "  - astrology_medicine (天文历算医学)"
echo "  - culture (文化)"
echo "  - grammar (语法)"
echo "  - history (历史)"
echo "  - literature (文学)"
echo "  - logic_philosophy (逻辑哲学)"
echo ""
echo "Test queries:"
echo "  curl \"http://localhost:9200/history/_search?q=question:བོད&size=3\""
echo "  curl \"http://localhost:9200/culture/_search?q=question:བཀྲ་ཤིས&size=3\""
echo ""

