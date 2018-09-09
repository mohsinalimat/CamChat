class ExampleClass{
    private var name: String
    init(){
        print("this was executed2")
        self.name = "alksdjflk"
    }
    
}


class ExampleClass2: ExampleClass{
    private var name: String
    
    override init(){
        self.name = "asdlkfjl"
        
    }
}


let x = ExampleClass2.init()















