tester = Tester.new(arr_len: 11, structs: [Heap, ImmutableHeap, AVLTree, ImmutableAVLTree, RubyRedBlack, NativeRedBlack])
csv_exporter = CSVExporter.new

insertion, sizes = tester.execute_all
csv_exporter.export_map("test.csv", sizes, insertion)