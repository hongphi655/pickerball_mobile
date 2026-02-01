using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PCM.API.Migrations
{
    /// <inheritdoc />
    public partial class AddLocationToCourt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "001_Courts",
                type: "nvarchar(max)",
                nullable: true);

            // Update locations for existing courts
            migrationBuilder.UpdateData(
                table: "001_Courts",
                keyColumn: "Id",
                keyValue: 1,
                column: "Location",
                value: "69 Lạch Tray, Hải Phòng");

            migrationBuilder.UpdateData(
                table: "001_Courts",
                keyColumn: "Id",
                keyValue: 2,
                column: "Location",
                value: "47 Lý Thái Tổ, Hoàn Kiếm, Hà Nội");

            migrationBuilder.UpdateData(
                table: "001_Courts",
                keyColumn: "Id",
                keyValue: 3,
                column: "Location",
                value: "Mỹ Đình, Từ Liêm, Hà Nội");

            migrationBuilder.UpdateData(
                table: "001_Courts",
                keyColumn: "Id",
                keyValue: 4,
                column: "Location",
                value: "200 Tây Sơn, Thanh Xuân, Hà Nội");

            migrationBuilder.UpdateData(
                table: "001_Courts",
                keyColumn: "Id",
                keyValue: 5,
                column: "Location",
                value: "Nam Từ Liêm, Hà Nội");

            migrationBuilder.UpdateData(
                table: "001_Courts",
                keyColumn: "Id",
                keyValue: 6,
                column: "Location",
                value: "Đống Đa, Hà Nội");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Location",
                table: "001_Courts");
        }
    }
}
