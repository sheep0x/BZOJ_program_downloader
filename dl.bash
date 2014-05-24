#! /usr/bin/env bash

# Copyright 2014 Chen Ruichao <linuxer.sheep.0x@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.





# In order to simplify the code, we use __foo__ instead of mktemp(1).
# Username is not URL encoded, but this should not be a problem.

# TODO HTTPS






# ==================== customization ====================
user_agent='Mozilla/5.0 (Windows NT 5.1; rv:27.0) Gecko/20100101 Firefox/27.0'

# custom arguments to pass to cURL
flags=(-A "$user_agent")





# ==================== initialization ====================
function abort()
{
    echo "error: $1"
    exit 1
}

function check_dep()
{
    which "$1" &>/dev/null || abort "$1 not installed"
}

check_dep curl
check_dep ruby


[[ $# == 1 ]] || {
    echo "Usage: $0 DIR"
    echo 'DIR will be used as the output directory as well as a temporary directory'
    exit 1
}

outpath=$1

if [[ ! -e $outpath ]]; then
    mkdir -p "$outpath"
elif ! [[ -d $outpath && -w $outpath ]]; then
    abort "$outpath is not a directory, or it is not writable"
elif [[ $(ls -A "$outpath" | wc -c) != 0 ]]; then
    abort "$outpath already exist, and it is not empty"
fi
cd "$outpath"



[[ -v flags ]] || flags=()

function curl()
{
    command curl "${flags[@]}" "$@"
}






# ==================== actual work ====================
function login()
{
    local usr=$1 pass=$2
    curl --data-urlencode "user_id=$usr"    \
         --data-urlencode "password=$pass"  \
         --data 'submit=Submit'             \
         --cookie-jar __cookie__            \
         'http://www.lydsy.com/JudgeOnline/login.php' &> /dev/null
}

function get()
{
    local page=$1
    curl --cookie __cookie__ \
        "http://www.lydsy.com/JudgeOnline/$page" \
        2>/dev/null
}

function cleanup()
{
    get 'logout.php' > /dev/null
    rm -f __cookie__
}




function handle_problem()
{
    local pid=$1
    local params="problem_id=$pid&user_id=$usr&language=-1&jresult=-1"
    echo "searching for problem $pid"

    local pat="%r{<tr align=center class='(?:even|odd)row'><td>"'(\d+)<td>.*?</tr>}'
    local list=() top='' id
    until
        id=''
        for id in $(get "status.php?$params$top" | ruby -e '$stdin.read.scan'"($pat) {|id| puts id }")
            do list+=($id); done
        [[ -z $id ]]
    do
        top="&top=$((id-1))"
    done

    local expand_ent='
        case ent
          when "&lt;"   then ?<
          when "&gt;"   then ?>
          when "&amp;"  then ?&
          when "&quot;" then ?"
          when "&apos;" then ?'"'"'
          else ent
        end
    '
    local find_source='s = $stdin.read[/<pre.*?>(.*?)<\/pre>/m, 1]'
    local preprocess='.delete("\r").gsub(/&[^;]+;/){|ent|'" $expand_ent }"
    local process_header='
        h = s.slice!(%r{\A/\*{62}.*?\*{64}/\n\n}m)
        lang = h[/^\tLanguage: (.*)$/, 1]
        stat = h[/^\tResult: (.*)$/  , 1] || "Unknown"
    '
    local write_file="
        stat_code = {
                      'Accepted'             => 'AC',
                      'Wrong_Answer'         => 'WA',
                      'Time_Limit_Exceed'    => 'TLE',
                      'Memory_Limit_Exceed'  => 'MLE',
                      'Output_Limit_Exceed'  => 'OLE',
                      'Presentation_Error'   => 'PE',
                      'Runtime_Error'        => 'RE',
                      'Compile_Error'        => 'CE',
                     #'Pending'
                     #'Pending_Rejudging'
                     #'Compiling'
                     #'Running_&_Judging'
                    }
        # .sh is not recommended
        lang_info = {
                      'C'        => ['c'   , false],
                      'C++'      => ['cpp' , false],
                      'Pascal'   => ['pas' , false],
                      'Java'     => ['java', false],
                      'Ruby'     => ['rb'  , true ],
                      'Bash'     => ['bash', true ],
                      'Python'   => ['py'  , true ],
                    }
        stat = stat_code[stat] || stat
        ext, is_script = lang_info[lang] || ['???', false]
        pid, runid = ARGV
        dir = 'BZOJ'+pid
        f = sprintf('BZOJ%s_%s_%s.%s', pid, runid, stat, ext)
        f = dir + '/' + f

        require 'fileutils'
        FileUtils.mkdir_p(dir)
        IO.write(f, s)
        FileUtils.chmod('ug+x', f) if is_script
    "

    for id in ${list[@]}; do
        echo "    downloading $id"
        get "showsource.php?id=$id" |
            ruby -e "$find_source$preprocess
                     $process_header
                     $write_file" \
                    $pid $id
    done
}







read -ep 'Username: ' usr
read -sp 'Password: ' pass; echo
login "$usr" "$pass"
trap cleanup EXIT


pat='/function p\(id\){[^}]*}\n((?:p\(\d+\);)+)<\/script>$/'
for pid in $(get "userinfo.php?user=$usr" | ruby -e "puts \$stdin.read[$pat,1][2..-3].split(');p(')")
    do handle_problem $pid; done
