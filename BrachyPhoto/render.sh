clean(){
sed -e 's/\(^\|[^*]\)\(\t\|* \|1\. \)//g' $1
}

main()
{
IN=${1:-MandM_BrachyCompMethod.md}
ALI=${IN%.*}
OPT="--filter pandoc-mustache --filter pandoc-citeproc"
#cat $ALI.md | 
clean $ALI.md | pandoc $OPT --webtex -f markdown -t html | tee $ALI.html \
| pandoc -f html -o $ALI.docx

}
main "$@"
