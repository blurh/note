package main

/*
   用于将有父子关系的列表转成树形结构
*/

import (
    "encoding/json"
    "fmt"
)

type Department struct {
    Id       int    `json:"id"`
    ParentId int    `json:"parentid"`
    Name     string `json:"name"`
}

type Node struct {
    Id       int     `json:"id"`
    ParentId int     `json:"parentid"`
    Name     string  `json:"name"`
    Children []*Node `json:"children"`
}

func (node *Node) corpTree(departments []*Department) {
    for _, dept := range departments {
        if node.Id == dept.ParentId {
            node.Children = append(node.Children,
                &Node{Id: dept.Id, ParentId: dept.ParentId, Name: dept.Name, Children: []*Node{}})
        }
    }
    if len(node.Children) != 0 {
        for _, childNode := range node.Children {
            childNode.corpTree(departments)
        }
    }
}

func main() {
    departments := []*Department{}
    departments = append(departments, &Department{Id: 1, ParentId: 0, Name: "root"})
    departments = append(departments, &Department{Id: 2, ParentId: 1, Name: "2"})
    departments = append(departments, &Department{Id: 3, ParentId: 1, Name: "3"})
    departments = append(departments, &Department{Id: 4, ParentId: 1, Name: "4"})
    departments = append(departments, &Department{Id: 5, ParentId: 2, Name: "5"})
    departments = append(departments, &Department{Id: 6, ParentId: 1, Name: "6"})
    departments = append(departments, &Department{Id: 7, ParentId: 3, Name: "7"})
    departments = append(departments, &Department{Id: 8, ParentId: 0, Name: "8"})
    departments = append(departments, &Department{Id: 9, ParentId: 2, Name: "9"})
    departments = append(departments, &Department{Id: 10, ParentId: 9, Name: "10"})
    departments = append(departments, &Department{Id: 11, ParentId: 10, Name: "11"})
    departments = append(departments, &Department{Id: 12, ParentId: 11, Name: "12"})
    departments = append(departments, &Department{Id: 13, ParentId: 0, Name: "13"})

    root := &Node{Id: 0}
    root.corpTree(departments)
    deptTree, _ := json.Marshal(root.Children)
    fmt.Println(string(deptTree))
}
