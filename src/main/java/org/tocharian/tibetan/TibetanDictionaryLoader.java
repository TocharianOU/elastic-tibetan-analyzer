/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.tocharian.tibetan;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Loads Tibetan dictionary resources from the plugin classpath.
 */
public class TibetanDictionaryLoader {
    public static Set<String> loadDictionary(String filename) throws IOException {
        Set<String> dictionary = new HashSet<>();
        String path = "/dictionaries/" + filename;
        
        try (InputStream is = getResourceAsStream(path);
             BufferedReader reader = new BufferedReader(
                 new InputStreamReader(is, StandardCharsets.UTF_8))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty() && !line.startsWith("#")) {
                    dictionary.add(line);
                }
            }
        }
        
        return dictionary;
    }
    
    public static List<String> loadDictionaryAsList(String filename) throws IOException {
        List<String> dictionary = new ArrayList<>();
        String path = "/dictionaries/" + filename;
        
        try (InputStream is = getResourceAsStream(path);
             BufferedReader reader = new BufferedReader(
                 new InputStreamReader(is, StandardCharsets.UTF_8))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty() && !line.startsWith("#")) {
                    dictionary.add(line);
                }
            }
        }
        
        return dictionary;
    }
    
    private static InputStream getResourceAsStream(String path) throws IOException {
        InputStream is = TibetanDictionaryLoader.class.getResourceAsStream(path);
        
        if (is == null) {
            is = TibetanDictionaryLoader.class.getResourceAsStream(path.substring(1));
        }
        
        if (is == null) {
            is = TibetanDictionaryLoader.class.getClassLoader().getResourceAsStream(path.substring(1));
        }
        
        if (is == null) {
            throw new IOException("Dictionary file not found: " + path);
        }
        
        return is;
    }
}
