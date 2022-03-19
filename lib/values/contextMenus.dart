import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:flutter/material.dart';

///The context menu for the regular song cards found on tracks page, album page and queue
final songCardContextMenulist=[
  ContextMenuOptions(
    id: 8,
    title: "Album",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 9,
    title: "Artist",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 1,
    title: "Play one",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 4,
    title: "Play Album",
    icon: Icons.album,
  ),
  ContextMenuOptions(
    id: 2,
    title: "Shuffle next queue",
    icon: Icons.shuffle,
  ),
  ContextMenuOptions(
    id: 3,
    title: "Shuffle next album",
    icon: Icons.shuffle,
  ),
  ContextMenuOptions(
    id: 5,
    title: "Cast",
    icon: Icons.cast_connected,
  ),
  ContextMenuOptions(
    id: 6,
    title: "Cast to new Device",
    icon: Icons.cast,
  ),
  ContextMenuOptions(
    id: 7,
    title: "Song information",
    icon: Icons.info_outline,
  ),
  ContextMenuOptions(
    id: 10,
    title: "Edit Tags",
    icon: Icons.edit,
  ),
];
///The context menu for the regular artist card found in the artists page
final artistCardContextMenulist=[
  ContextMenuOptions(
    id: 1,
    title: "Play All",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 2,
    title: "Shuffle",
    icon: Icons.shuffle,
  ),
];

///The context menu for the regular Album card found in the albums page
final albumCardContextMenulist=[
  ContextMenuOptions(
    id: 1,
    title: "Play Album",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 2,
    title: "Shuffle",
    icon: Icons.shuffle,
  ),
];

///The context menu for the regular playlist card foudn in the playlists page
final playlistCardContextMenulist=[
  ContextMenuOptions(
    id: 1,
    title: "Add new Songs",
    icon: Icons.add,
  ),
  ContextMenuOptions(
    id: 2,
    title: "Play All",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 3,
    title: "Shuffle",
    icon: Icons.shuffle,
  ),
  ContextMenuOptions(
    id: 4,
    title: "Edit playlist",
    icon: Icons.edit_attributes,
  ),
  ContextMenuOptions(
    id: 5,
    title: "Delete playlist",
    icon: Icons.delete,
  ),
];



///The context menu for the song cards found on a single playlist page
final playlistSongCardContextMenulist=[
  ContextMenuOptions(
    id: 1,
    title: "Play one",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 2,
    title: "Shuffle next playlist",
    icon: Icons.shuffle,
  ),
  ContextMenuOptions(
    id: 3,
    title: "Shuffle next album",
    icon: Icons.shuffle,
  ),
];


///The context menu for the song cards found on the search page for playlists
final playlistSearchSongCardContextMenulist=[
  ContextMenuOptions(
    id: 1,
    title: "Add one",
    icon: Icons.play_circle_outline,
  ),
  ContextMenuOptions(
    id: 2,
    title: "Add entire album",
    icon: Icons.shuffle,
  ),
];


///The context menu for the song cards found on the Edit Playlist page
final editPlaylistSongCardContextMenulist=[
  ContextMenuOptions(
    id: 1,
    title: "delete song",
    icon: Icons.delete,
  ),
];