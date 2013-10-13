# Generative Classification Models

The Homework 3 report from NTU102-1 [DMIR](https://ceiba.ntu.edu.tw/course/99b512/index.htm) course

**by NTU [Michael Hsu](http://michaelhsu.tw/ "blog")**


## Data Pre-process

1. 新增欄位 `index`：原本資料的排序（=sort by week_index + group ）。
2. 排序與篩選 `week_index` + `week_return1`： ![排序依據]()。
3. 定義分類標簽：
	- 1. 新增欄位 `index_sort`：根據上一個步驟後的排序。
	- 2. 新增欄位 `index_sort % 30`：`mod(左邊, 30)`
	- 3. 給予分類標籤 `class`：`=IF((左邊>0)*(左邊<=6),"1","0")` 前六個為 1，剩下二十四個為 0。
4. 新增欄位 `random_sort`：最後依據這個欄位 `=rand()` 來做 10-fold classification。