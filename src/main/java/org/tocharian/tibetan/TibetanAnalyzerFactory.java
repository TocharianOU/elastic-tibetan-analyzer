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

import org.apache.lucene.analysis.Analyzer;
import org.elasticsearch.plugin.NamedComponent;
import org.elasticsearch.plugin.analysis.AnalyzerFactory;

@NamedComponent(value = "tibetan_analyzer")
public class TibetanAnalyzerFactory implements AnalyzerFactory {
    @Override
    public Analyzer create() {
        return new TibetanAnalyzer();
    }
}
