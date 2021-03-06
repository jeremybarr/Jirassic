//
//  CellProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 10/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

protocol CellProtocol {

	var statusImage: NSImageView? {get}
	var data: TaskCreationData {get set}
	var duration: String {get set}
	
	var didEndEditingCell: ((cell: CellProtocol) -> ())? {get set}
	var didRemoveCell: ((cell: CellProtocol) -> ())? {get set}
	var didAddCell: ((cell: CellProtocol) -> ())? {get set}
	var didCopyContentCell: ((cell: CellProtocol) -> ())? {get set}
}