# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest
  module VERSION
    unless defined? MAJOR
      MAJOR  = 1
      MINOR  = 0
      TINY   = 0
      BUILD = 'beta6'
      
      STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')

      SUMMARY = "wrest version #{STRING}"
    end
  end
end
