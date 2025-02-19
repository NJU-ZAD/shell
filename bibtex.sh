#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ ! -n "$1" ] || ([ -n "$1" ] && [ $1 = "1" ]); then
    error=0
    echo "主目录为|"${HOME}
    echo "注意：有些会议（期刊）的缩写需要手动添加"
    read -p "输入bib文件的路径" path
    # path="${HOME}/123.bib"
    if [ ! -f "$path" ]; then
        echo "指定路径$path不存在！"
        exit
    fi
    line_nb=$(sed -n '$=' "$path")
    left_path="${path%/*}"
    right_path="${path##*/}"
    new_path=$left_path/standardized_$right_path
    temp_path=$left_path/temp_$right_path
    if [ -f "$new_path" ]; then
        rm -rf $new_path
    fi
    touch $new_path

    function include_line() {
        # 判断字符串是否是包含完整的行
        res=0
        if [[ "$read_line" =~ "@" ]]; then
            res1=$(echo "$read_line" | grep "@")
            res2=$(echo "$read_line" | grep "{")
            res3=$(echo "$read_line" | grep ",")
            if [ "$res1" != "" ] && [ "$res2" != "" ] && [ "$res3" != "" ]; then
                res=1
            fi
        elif [ "$read_line" = "}," ]; then
            res=3
        else
            res4=$(echo "$read_line" | grep "= \+{")
            res4_=$(echo "$read_line" | grep "={")
            res5=$(echo "$read_line" | grep "} \+,")
            res5_=$(echo "$read_line" | grep "},")
            if [ "$res4$res4_" != "" ] && [ "$res5$res5_" != "" ]; then
                res=2
            fi
        fi
    }

    function pre_process() {
        echo "正在对bib文件进行预处理"
        if [ -f "$temp_path" ]; then
            rm -rf $temp_path
        fi
        touch $temp_path
        read_line=""
        for ((i = 1; i <= $line_nb; i++)); do
            temp_line=$(sed -n ${i}p "$path")
            # echo "temp_line=$temp_line"
            read_line="$read_line$temp_line"
            read_line=$(echo "$read_line" | sed 's/\t//g')
            temp_line=$(echo "$read_line" | sed 's/ //g')
            if [ "$temp_line" != "" ]; then
                read_line=$(echo "$read_line" | awk '{gsub(/^\+|\+$/,"");print}')
                read_line=$(echo "$read_line" | sed 's/}$/},/g')
                # echo "read_line=$read_line"
                while :; do
                    include_line $read_line
                    # echo $res
                    # 将完整部分写入临时文件
                    if [ $res -eq 1 ]; then
                        write_line="${read_line%%,*}"
                        read_line="${read_line#*,}"
                        echo "$write_line," >>$temp_path
                    elif [ $res -eq 2 ]; then
                        read_line=$(echo "$read_line" | sed 's/},/@/g')
                        read_line=$(echo "$read_line" | sed 's/} \+,/@/g')
                        write_line="${read_line%%@*}"
                        read_line="${read_line#*@}"
                        read_line=$(echo "$read_line" | sed 's/@/},/g')
                        echo "$write_line}," >>$temp_path
                    elif [ $res -eq 3 ]; then
                        echo "$read_line" >>$temp_path
                        read_line=""
                    else
                        break
                    fi
                done
            fi
        done
        path=$temp_path
    }

    function check_symbol() {
        # 检查常规符号
        curr_line=$(echo "$curr_line" | sed 's/- \+/-/g')
        curr_line=$(echo "$curr_line" | sed 's/ \+-/-/g')
        curr_line=$(echo "$curr_line" | sed 's/{ \+/{/g')
        curr_line=$(echo "$curr_line" | sed 's/ \+}/}/g')
        curr_line=$(echo "$curr_line" | sed 's/(/ (/g')
        curr_line=$(echo "$curr_line" | sed 's/( \+/(/g')
        curr_line=$(echo "$curr_line" | sed 's/ \+)/)/g')
        curr_line=$(echo "$curr_line" | sed 's/ \+,/,/g')
        curr_line=$(echo "$curr_line" | sed 's/,/, /g')
        curr_line=$(echo "$curr_line" | sed 's/ \+$//g')
        curr_line=$(echo "$curr_line" | sed 's/ \+:/:/g')
        # 多空格归一化
        curr_line=$(echo "$curr_line" | sed 's/ \+/ /g')
    }

    function adjust_title_journal() {
        # 调整title或booktitle或journal的格式
        curr_line=$(echo "$curr_line" | sed 's/}$/},/g')
        curr_line=$(echo "$curr_line" | sed 's/{//g')
        curr_line=$(echo "$curr_line" | sed 's/}//g')
        curr_line=$(echo "$curr_line" | sed 's/\\//g')
        curr_line=$(echo "$curr_line" | sed 's/\$//g')
        curr_line=$(echo "$curr_line" | sed 's/=/={{/g')
        curr_line=$(echo "$curr_line" | sed 's/,$/}},/g')
        # 处理title中的^
        curr_line=$(echo "$curr_line" | sed 's/\^ \+/\\\^{}/g')
        # 处理title中的&
        curr_line=$(echo "$curr_line" | sed 's/&/\\\&/g')
        check_symbol
    }

    function special_case() {
        # 介（连）词小写和专有名词大写
        curr_line=$(echo "$curr_line" | sed 's/: \+/:/g')
        curr_line=$(echo "$curr_line" | sed 's/ Of / of /g')
        curr_line=$(echo "$curr_line" | sed 's/ For / for /g')
        curr_line=$(echo "$curr_line" | sed 's/ From / from /g')
        curr_line=$(echo "$curr_line" | sed 's/ Between / between /g')
        curr_line=$(echo "$curr_line" | sed 's/ With / with /g')
        curr_line=$(echo "$curr_line" | sed 's/ And / and /g')
        curr_line=$(echo "$curr_line" | sed 's/ The / the /g')
        curr_line=$(echo "$curr_line" | sed 's/ That / that /g')
        curr_line=$(echo "$curr_line" | sed 's/ Vs. / vs. /g')
        curr_line=$(echo "$curr_line" | sed 's/ Under / under /g')
        curr_line=$(echo "$curr_line" | sed 's/ At / at /g')
        curr_line=$(echo "$curr_line" | sed 's/-A-/-a-/g')
        curr_line=$(echo "$curr_line" | sed 's/-An-/-an-/g')
        curr_line=$(echo "$curr_line" | sed 's/ A / a /g')
        curr_line=$(echo "$curr_line" | sed 's/ An / an /g')
        curr_line=$(echo "$curr_line" | sed 's/ By / by /g')
        curr_line=$(echo "$curr_line" | sed 's/ In / in /g')
        curr_line=$(echo "$curr_line" | sed 's/ To / to /g')
        curr_line=$(echo "$curr_line" | sed 's/ Into / into /g')
        curr_line=$(echo "$curr_line" | sed 's/ On / on /g')
        curr_line=$(echo "$curr_line" | sed 's/ Over / over /g')
        curr_line=$(echo "$curr_line" | sed 's/ Empowered / empowered /g')
        curr_line=$(echo "$curr_line" | sed 's/ Of / of /g')
        curr_line=$(echo "$curr_line" | sed 's/:/: /g')

        curr_line=$(echo "$curr_line" | sed 's/Et Al./et al./g')
        curr_line=$(echo "$curr_line" | sed "s/'S/'s/g")
        curr_line=$(echo "$curr_line" | sed 's/Gpu/GPU/g')
        curr_line=$(echo "$curr_line" | sed 's/Cpu/CPU/g')
        curr_line=$(echo "$curr_line" | sed 's/Dnn/DNN/g')
        curr_line=$(echo "$curr_line" | sed 's/Arm/ARM/g')
    }

    function publisher() {
        # 设置会议（期刊）的出版社
        curr_line=$(echo "$curr_line" | sed 's/Ieee/IEEE/g')
        curr_line=$(echo "$curr_line" | sed 's/Acm/ACM/g')
        curr_line=$(echo "$curr_line" | sed 's/Usenix/USENIX/g')
        curr_line=$(echo "$curr_line" | sed 's/(IEEE/(/g')
        curr_line=$(echo "$curr_line" | sed 's/(ACM/(/g')
        curr_line=$(echo "$curr_line" | sed 's/(USENIX/(/g')
        curr_line=$(echo "$curr_line" | sed 's/( \+/(/g')
    }

    function check_type() {
        # 检查引用的类型
        echo "从"$start_line"行到"$end_line"行"
        for ((j = $start_line; j <= $end_line; j++)); do
            line=$(sed -n ${j}p "$path")
            line=$(echo "$line" | sed 's/\t//g')
            temp=$(echo "$line" | sed 's/ //g')
            if [ "$temp" != "" ]; then
                # 根据@判断类型
                type="misc"
                if [ $j -eq $start_line ]; then
                    if [[ $line =~ "@misc" ]] || [[ $line =~ "@Misc" ]] || [[ $line =~ "@MISC" ]]; then
                        type="misc"
                        break
                    elif [[ $line =~ "@book" ]] || [[ $line =~ "@Book" ]] || [[ $line =~ "@BOOK" ]] ||
                        [[ $line =~ "@inbook" ]] || [[ $line =~ "@Inbook" ]] || [[ $line =~ "@INBOOK" ]] ||
                        [[ $line =~ "@incollection" ]] || [[ $line =~ "@Incollection" ]] || [[ $line =~ "@INCOLLECTION" ]]; then
                        type="book"
                        break
                    elif [[ $line =~ "@proceedings" ]] || [[ $line =~ "@Proceedings" ]] || [[ $line =~ "@PROCEEDINGS" ]] ||
                        [[ $line =~ "@inproceedings" ]] || [[ $line =~ "@Inproceedings" ]] || [[ $line =~ "@INPROCEEDINGS" ]]; then
                        type="conference"
                        break
                    else
                        type="journal"
                    fi
                else
                    temp=$(echo $line | sed 's/ //g')
                    if [ "$temp" != "}" ]; then
                        # 根据字段判断类型
                        equal_left="${line%=*}"
                        if [[ $equal_left =~ "booktitle" ]] || [[ $equal_left =~ "journal" ]]; then
                            equal_right="${line#*=}"
                            if [[ $equal_right =~ "symposium" ]] || [[ $equal_right =~ "Symposium" ]] ||
                                [[ $equal_right =~ "conference" ]] || [[ $equal_right =~ "Conference" ]] ||
                                [[ $equal_right =~ "workshop" ]] || [[ $equal_right =~ "Workshop" ]]; then
                                type="conference"
                                break
                            elif [[ $equal_right =~ "journal" ]] || [[ $equal_right =~ "Journal" ]] ||
                                [[ $equal_right =~ "transactions" ]] || [[ $equal_right =~ "Transactions" ]]; then
                                type="journal"
                                break
                            elif [[ $equal_right =~ "proceedings" ]] || [[ $equal_right =~ "Proceedings" ]]; then
                                type="conference"
                                break
                            fi
                            if [[ $equal_left =~ "booktitle" ]]; then
                                type="conference"
                                break
                            elif [[ $equal_left =~ "journal" ]]; then
                                type="journal"
                                break
                            fi
                        fi
                    fi
                fi
            fi
        done
        echo $type
    }

    function remove_extra_blank() {
        # 去除字符串中=和{}控制下的多余空格
        if [ $k -eq $start_line ]; then
            left_line="${curr_line%%\{*}"
            right_line="${curr_line#*\{}"
            left_line=$(echo $left_line | sed 's/ //g')
            right_line=$(echo $right_line | sed 's/ //g')
            curr_line=$left_line{$right_line
        else
            temp=$(echo $curr_line | sed 's/ //g')
            if [ "$temp" != "}" ]; then
                left_line="${curr_line%%\{*}"
                temp_line="${curr_line#*\{}"
                mid_line="${temp_line%\}*}"
                right_line="${temp_line##*\}}"
                left_line=$(echo $left_line | sed 's/ //g')
                right_line=$(echo $right_line | sed 's/ //g')
                # echo "左"$left_line"中"$mid_line"右"$right_line
                curr_line=$left_line{$mid_line}$right_line
            fi
        fi
    }

    function judge_more_A_than_a() {
        local strings="$1"
        local A=0
        local a=0
        for ((i = 0; i < $(echo ${#strings}); i++)); do
            e=$(echo ${strings:$i:1})
            if [[ $e = [[:lower:]] ]]; then
                a=$(($a + 1))
            elif [[ $e = [[:upper:]] ]]; then
                A=$(($A + 1))
            fi
        done
        if [ $A -gt $a ]; then
            echo "1"
        else
            echo "0"
        fi
    }

    function rebuild_cite() {
        # 重新生成引用
        start_line=$1
        end_line=$2
        check_type
        for ((k = $start_line; k <= $end_line; k++)); do
            line=$(sed -n ${k}p "$path")
            # 去除所有TAB
            line=$(echo "$line" | sed 's/\t//g')
            # 考虑去除所有空格后的字符串
            temp=$(echo "$line" | sed 's/ //g')
            if [ "$temp" != "" ]; then
                # 去除字符串左右两边的空格
                curr_line=$(echo "$line" | awk '{gsub(/^\+|\+$/,"");print}')
                remove_extra_blank $start_line $curr_line $k
                # 确定@对象的形式
                if [[ $curr_line =~ "@" ]]; then
                    curr_line="${curr_line#*\{}"
                    if [ $type = "conference" ]; then
                        echo "@inproceedings{$curr_line" >>$new_path
                    elif [ $type = "journal" ]; then
                        echo "@article{$curr_line" >>$new_path
                    elif [ $type = "book" ]; then
                        echo "@book{$curr_line" >>$new_path
                    elif [ $type = "misc" ]; then
                        echo "@misc{$curr_line" >>$new_path
                    fi
                # 确定title的形式
                elif [[ $curr_line =~ "title" ]] && ! [[ $curr_line =~ "booktitle" ]]; then
                    adjust_title_journal
                    curr_line=$(echo "$curr_line" | sed 's/\b[a-z]/\U&/g')
                    curr_line=$(echo "$curr_line" | sed 's/Title={{/title={{/g')
                    special_case
                    echo "  $curr_line" >>$new_path
                # 确定author的形式
                elif [[ $curr_line =~ "author" ]]; then
                    curr_line=$(echo "$curr_line" | sed 's/{//g')
                    curr_line=$(echo "$curr_line" | sed 's/}//g')
                    curr_line=$(echo "$curr_line" | sed 's/=/={/g')
                    curr_line=$(echo "$curr_line" | sed 's/,$/},/g')
                    check_symbol
                    echo "  $curr_line" >>$new_path
                # 确定booktitle/journal的形式
                elif [[ $curr_line =~ "booktitle" ]] || [[ $curr_line =~ "journal" ]]; then
                    if [ $type = "conference" ] || [ $type = "journal" ]; then
                        curr_line=$(echo "$curr_line" | sed 's/in Proceedings of the//g')
                        curr_line=$(echo "$curr_line" | sed 's/in Proceedings of//g')
                        curr_line=$(echo "$curr_line" | sed 's/Proceedings of the//g')
                        curr_line=$(echo "$curr_line" | sed 's/Proceedings of//g')
                        if [ $type = "conference" ]; then
                            curr_line=$(echo $curr_line | sed 's/[iI]nterest /Interestt /g')
                            curr_line=$(echo $curr_line | sed 's/[-a-zA-Z0-9]\+st / /g')
                            curr_line=$(echo $curr_line | sed 's/Interestt /Interest /g')
                            curr_line=$(echo $curr_line | sed 's/ [aA]nd / andd /g')
                            curr_line=$(echo $curr_line | sed 's/[-a-zA-Z0-9]\+nd / /g')
                            curr_line=$(echo $curr_line | sed 's/ andd / and /g')
                            curr_line=$(echo $curr_line | sed 's/[-a-zA-Z0-9]\+th / /g')
                            curr_line=$(echo $curr_line | sed 's/[0-9]\+//g')
                        fi
                        adjust_title_journal
                        curr_line=$(echo "$curr_line" | sed 's/\b[a-z]/\U&/g')
                        special_case
                        publisher
                        if [ $type = "conference" ]; then
                            # 删除,之后的多余字段并添加,之后的会议缩写
                            curr_line=$(echo "$curr_line" | sed "s/USA//g")
                            abbrev0=$(echo "${curr_line#*,}")
                            abbrev=$abbrev0
                            while [[ "$abbrev" =~ "," ]]; do
                                temp_abbrev=$(echo "${abbrev%%,*}")
                                res=$(judge_more_A_than_a $temp_abbrev)
                                if [ "$res" = "1" ]; then
                                    break
                                fi
                                abbrev=$(echo "${abbrev#*,}")
                            done
                            if [[ "$abbrev0" =~ "," ]]; then
                                if [[ "$abbrev" =~ "," ]]; then
                                    # echo $abbrev
                                    # echo $temp_abbrev
                                    curr_line=$(echo "$curr_line" | sed "s#$abbrev#@#g")
                                    curr_line=$(echo "$curr_line" | sed 's/,@/}},/g')
                                    temp_abbrev=$(echo "$temp_abbrev" | sed "s#^ \+##g")
                                    curr_line=$(echo "$curr_line" | sed "s#}},# ($temp_abbrev)}},#g")
                                else
                                    curr_line=$(echo "$curr_line" | sed "s#$abbrev0#@#g")
                                    curr_line=$(echo "$curr_line" | sed 's/,@/}},/g')
                                fi
                            fi
                            # 删除-IEEE之前的多余字段并添加-IEEE之前的会议缩写
                            curr_line=$(echo "$curr_line" | sed 's/-IEEE/@/g')
                            if [[ $curr_line =~ "@" ]]; then
                                abbrev=$(echo "${curr_line%@*}")
                                abbrev=$(echo "$abbrev" | sed 's/IEEE//g')
                                abbrev=$(echo "$abbrev" | sed 's/[0-9]*//g')
                                abbrev=$(echo "$abbrev" | sed 's/ //g')
                                abbrev=$(echo "${abbrev##*\{}")
                                curr_line=$(echo "$curr_line" | sed 's/={{.*@/={{IEEE/g')
                                if [ "$abbrev" != "" ]; then
                                    curr_line=$(echo "$curr_line" | sed "s/}},/ ($abbrev)}},/g")
                                fi
                            fi
                            # 调整IEEE和ACM的格式
                            curr_line=$(echo "$curr_line" | sed 's/IEEE International/IEEE/g')
                            curr_line=$(echo "$curr_line" | sed 's/IEEE /IEEE International /g')
                            curr_line=$(echo "$curr_line" | sed 's#IEEE/ACM International#IEEE/ACM#g')
                            curr_line=$(echo "$curr_line" | sed 's#IEEE/ACM#IEEE/ACM International#g')
                        fi
                        # echo "$curr_line"
                        curr_line="${curr_line#*=}"
                        if [ $type = "conference" ]; then
                            curr_line="booktitle=$curr_line"
                            curr_line=$(echo "$curr_line" | sed 's/={{/={{Proceedings of the /g')
                        elif [ $type = "journal" ]; then
                            curr_line="journal=$curr_line"
                        fi
                        echo "  $curr_line" >>$new_path
                    else
                        # echo "删除booktitle/journal"
                        if [ $k -eq $end_line ]; then
                            echo "}" >>$new_path
                        fi
                    fi
                # 确定organization/publisher的形式
                elif [[ $curr_line =~ "organization" ]] || [[ $curr_line =~ "publisher" ]]; then
                    if [ $type = "conference" ] || [ $type = "journal" ]; then
                        # echo "删除organization/publisher"
                        if [ $k -eq $end_line ]; then
                            echo "}" >>$new_path
                        fi
                    elif [ $type = "book" ]; then
                        curr_line=$(echo "$curr_line" | sed 's/{//g')
                        curr_line=$(echo "$curr_line" | sed 's/}//g')
                        curr_line=$(echo "$curr_line" | sed 's/=/={/g')
                        curr_line=$(echo "$curr_line" | sed 's/,*$/},/g')
                        check_symbol
                        echo "  $curr_line" >>$new_path
                    fi
                elif [[ $curr_line =~ "editor" ]] || [[ $curr_line =~ "series" ]]; then
                    # echo "删除editor/series"
                    if [ $k -eq $end_line ]; then
                        echo "}" >>$new_path
                    fi
                else
                    check_symbol
                    # 确定该引用最后一行的形式
                    if [ $k -eq $end_line ]; then
                        temp=$(echo $curr_line | sed 's/ //g')
                        if [[ $temp =~ "}}" ]]; then
                            temp_line="${curr_line%%\}*}"
                            echo "  $temp_line}" >>$new_path
                            echo "}" >>$new_path
                        else
                            echo "}" >>$new_path
                        fi
                    else
                        echo "  $curr_line" >>$new_path
                    fi
                fi
            fi
        done
        echo >>$new_path
        echo
    }

    if [ -n "$1" ] && [ $1 = "1" ]; then
        pre_process
    fi

    cite_nb=0
    old_start=0
    start=0
    end=0
    for ((i = 1; i <= $line_nb; i++)); do
        line=$(sed -n ${i}p "$path")
        str=$(echo $line | sed 's/ //g')
        if ! [[ $line =~ "Encoding" ]] && ! [[ $line =~ "@Comment" ]]; then
            if [[ $line =~ "@" ]]; then
                let cite_nb++
                old_start=$start
                start=$i
                if [ $end -ne 0 ]; then
                    rebuild_cite $old_start $end
                fi
                echo "获取第"$cite_nb"个引用"
            elif [ "$str" != "" ]; then
                end=$i
            fi
        fi
    done
    if [ $start -ne 0 ] && [ $end -ne 0 ]; then
        rebuild_cite $start $end
    fi

    sed -i '$d' $new_path

    # 检查}后的逗号
    line_nb=$(sed -n '$=' "$new_path")
    let line_nb=line_nb-1
    for ((i = 1; i <= $line_nb; i++)); do
        line=$(sed -n ${i}p "$new_path")
        let j=i+1
        next=$(sed -n ${j}p "$new_path")
        if [ "$next" = "}" ]; then
            new_line=$(echo "*$line" | sed 's/},/}/g')
            sed -i "${i}c${new_line}" $new_path
        fi
    done
    sed -i "s/*//g" $new_path

    echo "已经生成"$new_path
    rm -rf $temp_path
fi

if [ $error = "1" ]; then
    echo "./bibtex.sh	快速模式（适用每个字段单独占据一行的情况）"
    echo "./bibtex.sh 1	完全模式（适用每个字段占据多行或多个字段占据一行的情况）"
fi

# TODO 解决会议/期刊的缩写问题
